From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: Re: [RFC v3 01/10] lsm: add security_socket_closed()
Date: Wed, 4 May 2011 00:29:29 +0900
Message-ID: <201105040029.IGA98088.SHOVQFLOMJtOFF@I-love.SAKURA.ne.jp>
References: <1304432663-1575-1-git-send-email-sam@synack.fr>
	<1304432663-1575-2-git-send-email-sam@synack.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org, hadi@cyberus.ca, kaber@trash.net,
	zbr@ioremap.net, root@localdomain.pl
To: sam@synack.fr, linux-security-module@vger.kernel.org
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <1304432663-1575-2-git-send-email-sam@synack.fr>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Samir Bellabes wrote:
> Allow a module to update security informations when a socket is closed.
Is security_inode_free() too late for doing it?

static void ccs_inode_free_security(struct inode *inode)
{
        if (inode->i_sb && inode->i_sb->s_magic == SOCKFS_MAGIC)
                ccs_update_socket_tag(inode, 0);
}
