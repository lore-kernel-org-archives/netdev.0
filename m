From: slavon@bigtelecom.ru
Subject: potentially kernel panic on lib/rbtree.c
Date: Sun, 02 Sep 2007 23:01:26 +0400
Message-ID: <20070902230126.bvcrzuiw1wogk40c@mail.himki.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset=windows-1251;
	DelSp="Yes";
	format="flowed"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.bigtelecom.ru ([87.255.0.61]:48614 "EHLO
	mail.bigtelecom.ru" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750991AbXIBTB2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Sep 2007 15:01:28 -0400
Received: from localhost (localhost [127.0.0.1])
	by mail.bigtelecom.ru (Postfix) with ESMTP id 192CEA6C0C7
	for <netdev@vger.kernel.org>; Sun,  2 Sep 2007 23:01:27 +0400 (MSD)
Received: from mail.bigtelecom.ru ([127.0.0.1])
	by localhost (mail.bigtelecom.ru [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id ww-wpMTg3K+W for <netdev@vger.kernel.org>;
	Sun,  2 Sep 2007 23:01:26 +0400 (MSD)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Sorry for prev. send =(

Hi all. Have some time panic from sch_htb.c

I see to gdb and see that panic at lib/rbtree.c:80
gparent == NULL

maybe add lines like this before IF

if (gparent == NULL){
     WARN_ON(1);
// MAYBE need remove parrent that not have gparent at this place? But  
i think that maybe its not  have gparent becouse its lock? No so deep  
look code.
     continue;
}

Thanks


----------------------------------------------------------------
This message was sent using IMP, the Internet Messaging Program.

