From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 1/3] net-PPP: Deletion of unnecessary checks before the
 function call "kfree"
Date: Mon, 01 Dec 2014 20:11:51 +0300
Message-ID: <547CA157.1080401@cogentembedded.com>
References: <5307CAA2.8060406@users.sourceforge.net> <alpine.DEB.2.02.1402212321410.2043@localhost6.localdomain6> <530A086E.8010901@users.sourceforge.net> <alpine.DEB.2.02.1402231635510.1985@localhost6.localdomain6> <530A72AA.3000601@users.sourceforge.net> <alpine.DEB.2.02.1402240658210.2090@localhost6.localdomain6> <530B5FB6.6010207@users.sourceforge.net> <alpine.DEB.2.10.1402241710370.2074@hadrien> <530C5E18.1020800@users.sourceforge.net> <alpine.DEB.2.10.1402251014170.2080@hadrien> <530CD2C4.4050903@users.sourceforge.net> <alpine.DEB.2.10.1402251840450.7035@hadrien> <530CF8FF.8080600@users.sourceforge.net> <alpine.DEB.2.02.1402252117150.2047@localhost6.localdomain6> <530DD06F.4090703@users.sourceforge.net> <alpine.DEB.2.02.1402262129250.2221@localhost6.localdomain6> <5317A59D.4@users.so
 urceforge.net> <547B4886.4080406@users.sourceforge.net> <547B496E.604@users.sourceforge.net> <547C5CBC.6060607@cogentembedded.com> <547C82A6.2030808@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
	kernel-janitors@vger.kernel.org,
	Julia Lawall <julia.lawall@lip6.fr>
To: SF Markus Elfring <elfring@users.sourceforge.net>,
	Paul Mackerras <paulus@samba.org>, linux-ppp@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <547C82A6.2030808@users.sourceforge.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 12/01/2014 06:00 PM, SF Markus Elfring wrote:

>>> diff --git a/drivers/net/ppp/ppp_mppe.c b/drivers/net/ppp/ppp_mppe.c
>>> index 911b216..7e44212 100644
>>> --- a/drivers/net/ppp/ppp_mppe.c
>>> +++ b/drivers/net/ppp/ppp_mppe.c
>>> @@ -238,8 +238,7 @@ static void *mppe_alloc(unsigned char *options, int optlen)
>>>        return (void *)state;
>>>
>>>        out_free:
>>> -        if (state->sha1_digest)
>>> -        kfree(state->sha1_digest);
>>> +    kfree(state->sha1_digest);

>>     Please keep this line aligned to the others.

> Can it be that the previous source code contained unwanted space
> characters at this place?

    Yes, it seems so.

> Do you want indentation fixes as a separate update step?

    Yes, that would be better to keep it separate.

> Regards,
> Markus

WBR, Sergei
