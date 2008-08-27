From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [RFC][PATCH] Turn part of SNMP accounting macros into functions
Date: Wed, 27 Aug 2008 20:58:38 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0808272035190.4613@wrl-59.cs.helsinki.fi>
References: <48B5815D.4010005@openvz.org> <Pine.LNX.4.64.0808271948000.4539@wrl-59.cs.helsinki.fi>
 <48B58A65.5060906@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: Pavel Emelyanov <xemul@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:41693 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751270AbYH0R6j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Aug 2008 13:58:39 -0400
In-Reply-To: <48B58A65.5060906@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 27 Aug 2008, Pavel Emelyanov wrote:

> Actually the complete bloat-o-meter.sh output showed that there were 
> ~10 functions, that became 8 bytes liter, ~10 that became 12-16 bytes
> liter and so on. This makes me think, that the code in the macro
> itself is pretty small, but is used widely in the networking code,
> and this spread makes such a big bloat.

I once measured all static inlines in the headers and the largest bloaters  
where of that type where the function itself is quite small but it's 
called from so many places that it add up.

-- 
 i.
