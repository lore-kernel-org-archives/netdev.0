From: jamal <hadi@cyberus.ca>
Subject: Re: [RFC PATCH 2/2] LSM: Make the Labeled IPsec hooks more stack
	friendly
Date: Tue, 08 Apr 2008 06:24:52 -0400
Message-ID: <1207650292.30750.43.camel@localhost>
References: <20080407231143.8087.77531.stgit@flek.lan>
	 <20080407231635.8087.42161.stgit@flek.lan>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux-security-module@vger.kernel.org, netdev@vger.kernel.org,
	selinux@tycho.nsa.gov
To: Paul Moore <paul.moore@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.177]:31135 "EHLO
	py-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750950AbYDHKYz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Apr 2008 06:24:55 -0400
Received: by py-out-1112.google.com with SMTP id u52so2866886pyb.10
        for <netdev@vger.kernel.org>; Tue, 08 Apr 2008 03:24:55 -0700 (PDT)
In-Reply-To: <20080407231635.8087.42161.stgit@flek.lan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2008-07-04 at 19:16 -0400, Paul Moore wrote:
> The xfrm_get_policy() and xfrm_add_pol_expire() put some rather large structs
> on the stack to work around the LSM API.

You missed a spot which applies similar logic:
net/key/af_key.c::pfkey_spddelete()

cheers,
jamal

