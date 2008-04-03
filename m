From: Jonas Bonn <jonas@southpole.se>
Subject: struct pci_device_id cleanups
Date: Thu, 03 Apr 2008 08:48:51 +0200
Message-ID: <47F47DD3.8090402@southpole.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.southpole.se ([193.12.106.18]:40173 "EHLO
	mail.southpole.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758096AbYDCGsx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Apr 2008 02:48:53 -0400
Received: from localhost (localhost [127.0.0.1])
	by mail.southpole.se (Postfix) with SMTP id C6FF9A0013
	for <netdev@vger.kernel.org>; Thu,  3 Apr 2008 08:48:51 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


In the "net" branch of my repo, there are a series of changesets that 
modify the definition of struct pci_device_id to use the macro 
DEFINE_PCI_DEVICE_TABLE.  All the changesets in the public tree are 
one-liners of the type:

-static struct pci_device_id myri10ge_pci_tbl[] = {
+static DEFINE_PCI_DEVICE_TABLE(myri10ge_pci_tbl) = {
	...

The change to using this macro has two effects:
i)  Makes the structure 'const'
ii)  Puts the structure in section __devinitconst

Both these changes are as per the documentation.

Please pull and review these changes from the "net" branch at:

git://www.southpole.se/~jonas/git/linux.git

Regards,
Jonas


