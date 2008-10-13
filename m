From: Ben Dooks <ben-linux@fluff.org>
Subject: Re: [patch 1/2] drivers/net/bonding: sparse fixes for exported
	tables
Date: Mon, 13 Oct 2008 10:23:47 +0100
Message-ID: <20081013092347.GA11059@fluff.org.uk>
References: <20080914155611.272940975@fluff.org.uk> <20080914155714.793765032@fluff.org.uk> <48DAF424.2060808@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ben Dooks <ben-linux@fluff.org>, netdev <netdev@vger.kernel.org>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aeryn.fluff.org.uk ([87.194.8.8]:47061 "EHLO
	kira.home.fluff.org" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755600AbYJMJYD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Oct 2008 05:24:03 -0400
Content-Disposition: inline
In-Reply-To: <48DAF424.2060808@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 24, 2008 at 10:15:00PM -0400, Jeff Garzik wrote:
> Ben Dooks wrote:
>> The following sparse warnings are being generated
>> because bonding.h is missing definitons for items
>> declared in bond_main.c but also used in bond_sysfs.h
>>
>> Also export bond_dev_list as this is also declared
>> in bond_main but used elsewhere in drivers/net/bonding.
>>
>> bond_main.c:105:20: warning: symbol 'bonding_defaults' was not declared. Should it be static?
>> bond_main.c:148:1: warning: symbol 'bond_dev_list' was not declared. Should it be static?
>> bond_main.c:162:22: warning: symbol 'bond_lacp_tbl' was not declared. Should it be static?
>> bond_main.c:168:22: warning: symbol 'bond_mode_tbl' was not declared. Should it be static?
>> bond_main.c:179:22: warning: symbol 'xmit_hashtype_tbl' was not declared. Should it be static?
>> bond_main.c:186:22: warning: symbol 'arp_validate_tbl' was not declared. Should it be static?
>> bond_main.c:194:22: warning: symbol 'fail_over_mac_tbl' was not declared. Should it be static?
>>
>> Signed-off-by: Ben Dooks <ben-linux@fluff.org>
>>
>> Index: linux-git-test-next-cats/drivers/net/bonding/bonding.h
>> ===================================================================
>> --- linux-git-test-next-cats.orig/drivers/net/bonding/bonding.h	2008-09-14 16:39:30.000000000 +0100
>> +++ linux-git-test-next-cats/drivers/net/bonding/bonding.h	2008-09-14 16:44:24.000000000 +0100
>> @@ -333,5 +333,13 @@ void bond_change_active_slave(struct bon
>>  void bond_register_arp(struct bonding *);
>>  void bond_unregister_arp(struct bonding *);
>>  +/* exported from bond_main.c */
>> +extern struct list_head bond_dev_list;
>> +extern struct bond_parm_tbl bond_lacp_tbl[];
>> +extern struct bond_parm_tbl bond_mode_tbl[];
>> +extern struct bond_parm_tbl xmit_hashtype_tbl[];
>> +extern struct bond_parm_tbl arp_validate_tbl[];
>> +extern struct bond_parm_tbl fail_over_mac_tbl[];
>
> applied
>
> patch #2 failed to apply

ok, will sort this out and send a new patch.

-- 
Ben (ben@fluff.org, http://www.fluff.org/)

  'a smiley only costs 4 bytes'
