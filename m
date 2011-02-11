From: Ajit Khaparde <ajit.khaparde@emulex.com>
Subject: [PATCH net-next 00/15] be2net: patch series
Date: Fri, 11 Feb 2011 17:32:15 -0600
Message-ID: <20110211233215.GA18258@akhaparde-VBox>
Reply-To: Ajit Khaparde <ajit.khaparde@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: <netdev@vger.kernel.org>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht1.emulex.com ([138.239.113.183]:51104 "EHLO
	exht1.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756321Ab1BKXci (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Feb 2011 18:32:38 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patch series for the be2net driver.

[01/15]: While configuring QOS for VF, pass proper domain id
[02/15]: endianness fix in be_cmd_set_qos().
[03/15]: Use domain id when be_cmd_if_destroy is called.
[04/15]: Initialize and cleanup sriov resources only if pci_enable_sriov has succeeded.
[05/15]: call be_vf_eth_addr_config() after register_netdev
[06/15]: Cleanup the VF interface handles
[07/15]: For the VF MAC, use the OUI from current MAC address
[08/15]: pass domain numbers for pmac_add/del functions
[09/15]: Allow VFs to call be_cmd_reset_function.
[10/15]: Fix broken priority setting when vlan tagging is enabled.
[11/15]: pass proper hdr_size while flashing redboot.
[12/15]: fix be_suspend/resume/shutdown
[13/15]: gracefully handle situations when UE is detected
[14/15]: detect a UE even when a interface is down.
[15/15]: restrict WOL to PFs only.

Please Apply.

Thanks
-Ajit
