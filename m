From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net] bna: don't disable VLAN tag stripping in promisc mode
Date: Thu, 27 Feb 2014 20:59:23 +0100
Message-ID: <20140227195923.GA2901@minipsycho.orion>
References: <1393525042-7791-1-git-send-email-ivecera@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Rasesh Mody <rmody@brocade.com>
To: Ivan Vecera <ivecera@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f44.google.com ([74.125.83.44]:44653 "EHLO
	mail-ee0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751067AbaB0T70 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Feb 2014 14:59:26 -0500
Received: by mail-ee0-f44.google.com with SMTP id d49so1719634eek.3
        for <netdev@vger.kernel.org>; Thu, 27 Feb 2014 11:59:25 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1393525042-7791-1-git-send-email-ivecera@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thu, Feb 27, 2014 at 07:17:22PM CET, ivecera@redhat.com wrote:
>The recent commit "fe1624c bna: RX Filter Enhancements" disables
>VLAN tag stripping if the NIC is in promiscuous mode. Received VLAN tagged
>packets are recognized by the driver via BNA_CQ_EF_VLAN flag and for such
>packets the driver calls __vlan_hwaccel_put_tag(). The problem is the HW
>marks the tagged packets with this flags also when the stripping is
>disabled and thus __vlan_hwaccel_put_tag() should not be called for them.
>
>A solution can be to call __vlan_hwaccel_put_tag() only when stripping is
>enabled or to leave VLAN stripping engine enabled. The 2nd restores the
>previous behavior and is IMHO better.
>
>Cc: Rasesh Mody <rmody@brocade.com>
>Signed-off-by: Ivan Vecera <ivecera@redhat.com>
Reviewed-by: Jiri Pirko <jiri@resnulli.us>
