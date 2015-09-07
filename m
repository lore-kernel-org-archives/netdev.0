From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH] ip link/addr show: add empty line between interfaces
Date: Mon, 7 Sep 2015 14:46:09 +0200
Message-ID: <20150907144609.3ec9f4d0@griffin>
References: <1441537269-13899-1-git-send-email-felix.kaiser@fxkr.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Felix Kaiser <felix.kaiser@fxkr.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56873 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751222AbbIGMqM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Sep 2015 08:46:12 -0400
In-Reply-To: <1441537269-13899-1-git-send-email-felix.kaiser@fxkr.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun,  6 Sep 2015 13:01:09 +0200, Felix Kaiser wrote:
> This improves the readability of the output.

Or makes the readability worse by requiring more scrolling, depending
on number of interfaces you have and your taste. Many users prefer the
current format.

Also, as sad as it is, there are scripts out there that parse ip output
and I have no doubts this would break them.

 Jiri

-- 
Jiri Benc
