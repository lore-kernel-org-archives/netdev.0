From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 2/3] staging: r8188eu: Fix case where ethtype was never
 obtained and always be checked against 0
Date: Wed, 09 Apr 2014 23:11:52 +0400
Message-ID: <53459B78.7090709@cogentembedded.com>
References: <1397059980-11942-1-git-send-email-Larry.Finger@lwfinger.net> <1397059980-11942-3-git-send-email-Larry.Finger@lwfinger.net> <53457428.4030408@cogentembedded.com> <20140409190204.GD26890@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Larry Finger <Larry.Finger@lwfinger.net>,
	gregkh@linuxfoundation.org, devel@driverdev.osuosl.org,
	netdev@vger.kernel.org, Stable <stable@vger.kernel.org>
To: Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <20140409190204.GD26890@mwanda>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 04/09/2014 11:02 PM, Dan Carpenter wrote:

>>> diff --git a/drivers/staging/rtl8188eu/core/rtw_recv.c b/drivers/staging/rtl8188eu/core/rtw_recv.c
>>> index 01fcabc..61084d6 100644
>>> --- a/drivers/staging/rtl8188eu/core/rtw_recv.c
>>> +++ b/drivers/staging/rtl8188eu/core/rtw_recv.c
>>> @@ -551,7 +551,7 @@ static struct recv_frame *portctrl(struct adapter *adapter,
>>>   	struct sta_info *psta;
>>>   	struct sta_priv *pstapriv;
>>>   	struct recv_frame *prtnframe;
>>> -	u16	ether_type = 0;
>>> +	u16	ether_type;

>>     I suggest:

>> 	u16 ethertype;

> I don't understand this suggestion.  Why is that name prefered?

    Sorry, I've managed to somehow remove the underscore. :-/
My real suggestion was to replace the tab with a space.

> regards,
> dan carpenter

WBR, Sergei
