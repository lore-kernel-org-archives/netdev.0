From: "Tom Spink" <tspink@gmail.com>
Subject: Re: AF_UNIX MSG_PEEK bug?
Date: Tue, 8 Jan 2008 22:53:59 +0000
Message-ID: <7b9198260801081453s198af7efycc7c35668c65eaf1@mail.gmail.com>
References: <alpine.BSF.1.00.0801081556580.24286@pkunk.americas.sgi.com>
	 <4783FBD6.1000004@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Brent Casavant" <bcasavan@sgi.com>, netdev@vger.kernel.org,
	"David Miller" <davem@davemloft.net>, linux-kernel@vger.kernel.org
To: "Rick Jones" <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.178]:59385 "EHLO
	py-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752143AbYAHWyA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jan 2008 17:54:00 -0500
Received: by py-out-1112.google.com with SMTP id u52so5839pyb.10
        for <netdev@vger.kernel.org>; Tue, 08 Jan 2008 14:53:59 -0800 (PST)
In-Reply-To: <4783FBD6.1000004@hp.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/01/2008, Rick Jones <rick.jones2@hp.com> wrote:
> Potential bugs notwithstanding, given that this is a STREAM socket, and
> as such shouldn't (I hope, or I'm eating toes for dinner again) have
> side effects like tossing the rest of a datagram, why are you using
> MSG_PEEK?  Why not simply read the N bytes of the message that will have
> the message length with a normal read/recv, and then read that many
> bytes in the next call?
>
> rick jones
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
>

Hi,

Where in the code is the message length being sent across the socket?

-- 
Regards,
Tom Spink
University of Edinburgh
