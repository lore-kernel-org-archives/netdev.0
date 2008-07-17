From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: git clone net-next-2.6
Date: Thu, 17 Jul 2008 13:41:21 +0800
Message-ID: <487EDB81.6080809@cn.fujitsu.com>
References: <487C0ABA.1070506@cn.fujitsu.com>	<487C12A5.8010505@cn.fujitsu.com> <20080714.210056.47426171.davem@davemloft.net> <487C3DFF.1050809@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:49567 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751909AbYGQFqj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Jul 2008 01:46:39 -0400
In-Reply-To: <487C3DFF.1050809@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wang Chen said the following on 2008-7-15 14:04:
> But I need some help from you, otherwise the latest tree to me is Linus's
> mainline tree.
> Actually, long time ago, I want to git-clone your net tree but failed.
> But I can git-clone Linus's.
> The reason is that in my working place I can only use http protocol when git
> clone. But your tree seems not work for http git-clone.
> I asked Herbert before, he said, maybe git-update-server-info needs to be
> executed.
> I am very appreciated if you can figure out why net tree can't be cloned by http.
> And maybe there are some other people whose employer's firewall filtering git
> port.
> Thank you for your understanding in advance :)
> 

David, git-clone your net-next-2.6 tree by http can work now.
But, it failed half way.
BTW, I am not urgent :)

---
# git-clone http://www.kernel.org/pub/scm/linux/kernel/git/davem/net-next-2.6.git
Initialized empty Git repository in /pub/git/wcn/davem/net-next-2.6/.git/
Getting alternates list for http://www.kernel.org/pub/scm/linux/kernel/git/davem/net-next-2.6.git
Also look at http://www.kernel.org/home/ftp/pub/scm/linux/kernel/git/torvalds/linux-2.6.git/
Getting pack list for http://www.kernel.org/pub/scm/linux/kernel/git/davem/net-next-2.6.git
Getting index for pack b4c5447ecf8fe5dd18e4403f6628e52579ba93aa
Getting pack b4c5447ecf8fe5dd18e4403f6628e52579ba93aa
 which contains 79d16385c7f287a33ea771c4dbe60ae43f791b49
walk 79d16385c7f287a33ea771c4dbe60ae43f791b49
walk b19fa1fa91845234961c64dbd564671aa7c0fd27
Getting pack list for http://www.kernel.org/home/ftp/pub/scm/linux/kernel/git/torvalds/linux-2.6.git/
error: Unable to find 869e1a3b64b6bf969eeced820691e955e03e3068 under http://www.kernel.org/pub/scm/linux/kernel/git/davem/net-next-2.6.git
Cannot obtain needed blob 869e1a3b64b6bf969eeced820691e955e03e3068
while processing commit b19fa1fa91845234961c64dbd564671aa7c0fd27.

