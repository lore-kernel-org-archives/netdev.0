From: Jiri Benc <jbenc@suse.cz>
Subject: Re: [PATCH wireless-dev] d80211: Replace rc4 code with crypto api
 arc4
Date: Thu, 13 Jul 2006 13:03:27 +0200
Message-ID: <20060713130327.228eec9c@griffin.suse.cz>
References: <200607130140.09916.flamingice@sourmilk.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@tuxdriver.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:57793 "EHLO mail.suse.cz")
	by vger.kernel.org with ESMTP id S1751515AbWGMLDc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Jul 2006 07:03:32 -0400
To: Michael Wu <flamingice@sourmilk.net>
In-Reply-To: <200607130140.09916.flamingice@sourmilk.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 13 Jul 2006 01:39:59 -0700, Michael Wu wrote:
> This patch replaces the rc4 code used in wep.c with crypto api's arc4
> cipher. The struct crypto_tfm passing in tkip isn't great, but it'll get fixed
> when tkip is converted to use crypto api entirely. (michael_mic)

Great work! Thanks, I'll apply the patch to my tree (there is a minor
conflict) and push it to John eventually.

 Jiri

-- 
Jiri Benc
SUSE Labs
