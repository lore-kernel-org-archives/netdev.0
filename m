From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next] switchdev: fdb filter_dev is always NULL for
 self (device), so remove check
Date: Thu, 18 Jun 2015 11:22:08 +0200
Message-ID: <20150618092208.GB2136@nanopsycho.orion>
References: <1434582511-46290-1-git-send-email-sfeldma@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, sridhar.samudrala@intel.com
To: sfeldma@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f54.google.com ([74.125.82.54]:36749 "EHLO
	mail-wg0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752968AbbFRJWL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Jun 2015 05:22:11 -0400
Received: by wgzl5 with SMTP id l5so58313505wgz.3
        for <netdev@vger.kernel.org>; Thu, 18 Jun 2015 02:22:10 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1434582511-46290-1-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thu, Jun 18, 2015 at 01:08:31AM CEST, sfeldma@gmail.com wrote:
>From: Scott Feldman <sfeldma@gmail.com>
>
>Remove the filter_dev check when dumping fdb entries, otherwise dump
>returns empty list.  filter_dev is always passed as NULL when dumping fdbs
>on SELF.  We want the fdbs installed on the device to be listed in the
>dump.
>
>Signed-off-by: Scott Feldman <sfeldma@gmail.com>

Acked-by: Jiri Pirko <jiri@resnulli.us>
