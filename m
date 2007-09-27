From: "Rami Rosen" <roszenrami@gmail.com>
Subject: Re: IPSec on Linux Kernel
Date: Thu, 27 Sep 2007 17:23:30 +0200
Message-ID: <b25312890709270823i6780a612u9f5768987de4a7e5@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.191]:65459 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756180AbXI0PXp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Sep 2007 11:23:45 -0400
Received: by nf-out-0910.google.com with SMTP id g13so2247502nfb
        for <netdev@vger.kernel.org>; Thu, 27 Sep 2007 08:23:43 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,Fabio,

  - Assuming that you intend to deal with IPV4, I suggest that you will
start by looking at the ah4.ko module sources, which are in net/ipv4/ah.c,
especially at the ah_output() and the ah_input() methods.

(for ipv6 there are the ah6.c in net/ipv6).

- May I ask: are you aware that the Authentication Header protocol deals
only with authentication and not with encryption? and as a result, the ESP
protocol, which supports authentication and also, when needed, encryption, is
much more widely used?

Regards,
  Rosen Rami
