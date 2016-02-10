From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Scaling the Number of Network Interfaces on Linux
Date: Wed, 10 Feb 2016 12:15:55 +0100
Message-ID: <56BB1BEB.5090200@6wind.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Roopa Prabhu <roopa@cumulusnetworks.com>,
	David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f44.google.com ([74.125.82.44]:33628 "EHLO
	mail-wm0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750993AbcBJLP6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Feb 2016 06:15:58 -0500
Received: by mail-wm0-f44.google.com with SMTP id g62so22305455wme.0
        for <netdev@vger.kernel.org>; Wed, 10 Feb 2016 03:15:57 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David, Roopa,

to follow your talk at nedev11, I already proposed some times ago a patch to
remove sysctl, which was rejected. You can see the thread here:
http://thread.gmane.org/gmane.linux.network/285840

Instead of removing completly the sysctl entries, another idea could be to
manage a group of interfaces which will share the same subtree.


Regards,
Nicolas
