From: "Jeff Kirsher" <jeffrey.t.kirsher@intel.com>
Subject: Re: Huge packet loss on Intel 80003ES2LAN
Date: Wed, 23 Jul 2008 08:57:51 -0700
Message-ID: <9929d2390807230857j2afdf865r2084d3e3e6cb537f@mail.gmail.com>
References: <4885B79E.8060704@yandex-team.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, e1000-devel@lists.sourceforge.net
To: "Vlad Seliverstov" <vseliverstov@yandex-team.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.176]:57817 "EHLO
	py-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750799AbYGWP5w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jul 2008 11:57:52 -0400
Received: by py-out-1112.google.com with SMTP id p76so1780617pyb.10
        for <netdev@vger.kernel.org>; Wed, 23 Jul 2008 08:57:51 -0700 (PDT)
In-Reply-To: <4885B79E.8060704@yandex-team.ru>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 22, 2008 at 3:34 AM, Vlad Seliverstov
<vseliverstov@yandex-team.ru> wrote:
> Hi.
>
> Recently, I moved my heavily network-loaded server under Ubuntu Hardy to a
> box with two 80003ES2LAN onboard NICs and began to experience problems with
> it. The problem is huge packet loss time to time.
> Here are ping results from another server (which has address 192.168.0.2) in
> the same network segment:
>

While your current version of e1000 driver does support that
particular NIC, the latest e1000 driver has support removed for this
NIC and support has been moved to the e1000e driver.  Please try the
latest driver (e1000e).
The latest e1000e driver (version 0.4.1.7) can be found on http://e1000.sf.net/

-- 
Cheers,
Jeff
