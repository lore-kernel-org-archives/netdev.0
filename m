From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Subject: Re: [RFC] New driver API to speed up small packets xmits
Date: Fri, 11 May 2007 07:26:16 +1200
Message-ID: <5640c7e00705101226j55eb439cj402db82fc687e3c3@mail.gmail.com>
References: <OF305F038C.A48D4C37-ON652572D7.00538ECA-652572D7.00546E39@in.ibm.com>
	 <46435412.50800@hp.com> <464360D6.4080402@hp.com>
	 <46436274.4060804@hp.com> <4643654F.5060207@hp.com>
	 <5640c7e00705101159w68750a47xc06495e4395de583@mail.gmail.com>
	 <464370BA.3020907@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Rick Jones" <rick.jones2@hp.com>,
	"Krishna Kumar2" <krkumar2@in.ibm.com>,
	"Evgeniy Polyakov" <johnpol@2ka.mipt.ru>, netdev@vger.kernel.org
To: "Vlad Yasevich" <vladislav.yasevich@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nz-out-0506.google.com ([64.233.162.235]:12831 "EHLO
	nz-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754775AbXEJT0R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 May 2007 15:26:17 -0400
Received: by nz-out-0506.google.com with SMTP id o1so726569nzf
        for <netdev@vger.kernel.org>; Thu, 10 May 2007 12:26:16 -0700 (PDT)
In-Reply-To: <464370BA.3020907@hp.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 5/11/07, Vlad Yasevich <vladislav.yasevich@hp.com> wrote:
> The win might be biggest on a system were a lot of applications send a lot of
> small packets.  Some number will aggregate in the prio queue and then get shoved
> into a driver in one go.

That's assuming that the device doesn't run out of things to send first....
>
> But...  this is all conjecture until we see the code.
>
Agree

-- 
Web: http://wand.net.nz/~iam4/
Blog: http://iansblog.jandi.co.nz
WAND Network Research Group
