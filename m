From: "kalash nainwal" <kalash.nainwal@gmail.com>
Subject: Re: ip_finish_outpu2 question
Date: Wed, 14 May 2008 14:17:58 +0530
Message-ID: <416aa1ad0805140147m2efff9b1v6a5f8c3d0ee701c6@mail.gmail.com>
References: <7aa53e090805132042k5476eaf6lb66e534232154bf5@mail.gmail.com>
	 <20080513.213425.03637016.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: bshanth@gmail.com, netdev@vger.kernel.org
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fk-out-0910.google.com ([209.85.128.185]:22064 "EHLO
	fk-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752700AbYENIsA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 May 2008 04:48:00 -0400
Received: by fk-out-0910.google.com with SMTP id 18so2628845fkq.5
        for <netdev@vger.kernel.org>; Wed, 14 May 2008 01:47:59 -0700 (PDT)
In-Reply-To: <20080513.213425.03637016.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 14, 2008 at 10:04 AM, David Miller <davem@davemloft.net> wrote:
> From: Prashanth <bshanth@gmail.com>
> Date: Wed, 14 May 2008 09:12:54 +0530
>
>> hi, In the following function at line 189 , we are getting aligned
>> length (hh_alen) for the hardware header , but while doing a
>> skb_push() why are we using the hh->hh_len;for ethernet hh_alen would
>> be 16 , and hh->hh_len would be 14, since we are doing skb_push() with
>> 14 (i.e hh->hh_len), the skb->data will not be aligned right? Can
>> someone please shed some light on this. thanks.
>
> We are using 16 for the copy so that we do an aligned
> copy.  But the ethernet header size is only 14 bytes.
>

I thought memcpy in linux is anyway always alignment safe. no?

-Kalash
