From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: Re: bugfix: wireless bug causing working setups to loose net connectivity
Date: Mon, 21 Sep 2009 20:44:22 +0200
Message-ID: <4AB7C986.9040304@hartkopp.net>
References: <200909212035.50592.a.miskiewicz@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Johannes Berg <johannes@sipsolutions.net>, netdev@vger.kernel.org
To: Arkadiusz Miskiewicz <a.miskiewicz@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.160]:20998 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753017AbZIUSoU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Sep 2009 14:44:20 -0400
In-Reply-To: <200909212035.50592.a.miskiewicz@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Arkadiusz Miskiewicz wrote:
> Could 
> http://marc.info/?l=linux-wireless&m=125323296617306&w=2
> be merged without waiting for separate wireless pull request?
> 
> Currently previously working setups are no longer able to connect to AP (in my 
> case WPA2PSK via wpasupplicant).
> 
> AFAIK there was some kind of policy where bugfixes that break basic 
> functionality are supposed to be merged fast to allow to actually use and test 
> git kernel.

For me it was

http://git.kernel.org/?p=linux/kernel/git/davem/net-2.6.git;a=commitdiff;h=bbac31f4c0339f6c51afbd0edfb4959df9b53fa9

as written here:

http://marc.info/?l=linux-netdev&m=125352781320953&w=2

Maybe you can try to revert this patch in your setup too, to check whether it
also solves your issue.

Regards,
Oliver

