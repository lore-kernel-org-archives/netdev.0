From: Sudhir Kumar <skumar@linux.vnet.ibm.com>
Subject: [BUILD FAILURE]2.6.24-git10 section type conflict
Date: Fri, 1 Feb 2008 23:56:27 +0530
Message-ID: <20080201182627.GB14251@in.ibm.com>
Reply-To: skumar@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: sam ravnborg <sam@ravnborg.org>,
	net-dev-mailing list <netdev@vger.kernel.org>
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e35.co.us.ibm.com ([32.97.110.153]:51348 "EHLO
	e35.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753083AbYBASX1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Feb 2008 13:23:27 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi All,
I found the following kernel build failure for 2.6.24-git10
on my machine:

  CC [M]  drivers/scsi/lpfc/lpfc_attr.o
drivers/net/sis190.c:329: error: sis190_pci_tbl causes a section type
conflict
make[2]: *** [drivers/net/sis190.o] Error 1
make[1]: *** [drivers/net] Error 2
make[1]: *** Waiting for unfinished jobs....
  CC [M]  drivers/scsi/lpfc/lpfc_vport.o


machine info:
[root@x330d ~]# uname -a
Linux x330d.in.ibm.com 2.6.24-rc8 #1 SMP Thu Jan 31 16:46:34 NPT 2008
i686 i686 i386 GNU/Linux

Thanks

Sudhir Kumar
Linux Technology Centre
Bangalore
