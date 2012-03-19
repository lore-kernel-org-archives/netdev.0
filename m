From: Denys Fedoryshchenko <denys@wbc.net.sa>
Subject: kernel 3.3, regression, bnx2 firmware missing in tar.bz2
Date: Tue, 20 Mar 2012 01:31:06 +0300
Message-ID: <4F67B3AA.9070900@wbc.net.sa>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailnew.wbc.net.sa ([77.87.16.6]:56066 "EHLO mx.wbc.net.sa"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1758143Ab2CSW55 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Mar 2012 18:57:57 -0400
Received: from [188.53.74.59] (helo=[192.168.2.210])
	by mx.wbc.net.sa with esmtpsa (TLSv1:AES256-SHA:256)
	(Exim 4.76)
	(envelope-from <denys@wbc.net.sa>)
	id 1S9l6i-0008R4-S7
	for netdev@vger.kernel.org; Tue, 20 Mar 2012 01:31:16 +0300
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi

Just loaded to 2.6.39 machine newest 3.3 kernel and got dead network 
interface:

Mar 20 03:28:37 localhost kernel: bnx2: Can't load firmware file 
"bnx2/bnx2-mips-06-6.2.3.fw"

On one side i agree that firmware can have non-GPL license, but at any 
case while it is working in old kernel, if it is dead in new - and it is 
very bad. Just checked commit

Actually i am expecting to have working network interfaces with 
downloaded tar.bz2 of stable kernel release, especially if it was 
working before, otherwise it is plain regression. Or i am wrong?

Sure i know how to use git, but it is non-trivial to find about git tree 
with this firmware in git.kernel.org, nothing mentioned in 
documentation. It will be perfect, if make process at least will try to 
fetch firmwares from git or note about it at end of compiling.

Thanks.


	
