From: Vincent Hanquez <tab@snarc.org>
Subject: Re: [PATCH] BSD Jail LSM
Date: Tue, 14 Sep 2004 01:58:28 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040913235828.GA7212@snarc.org>
References: <1094847705.2188.94.camel@serge.austin.ibm.com> <1094847787.2188.101.camel@serge.austin.ibm.com> <1094844708.18107.5.camel@localhost.localdomain> <20040912233342.GA12097@escher.cs.wm.edu> <1095072996.14355.12.camel@localhost.localdomain> <1095117605.2350.11.camel@serge.austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, Chris Wright <chrisw@osdl.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        akpm@osdl.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Serge Hallyn <serue@us.ibm.com>
Content-Disposition: inline
In-Reply-To: <1095117605.2350.11.camel@serge.austin.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, Sep 13, 2004 at 06:20:05PM -0500, Serge Hallyn wrote:
> +#define in_use(x) (x->jail_flags & IN_USE)
> +#define set_in_use(x) (x->jail_flags |= IN_USE)
> +
> +#define got_network(x) (x->jail_flags & (GOT_IPV4 | GOT_IPV6))
> +#define got_ipv4(x) (x->jail_flags & (GOT_IPV4))
> +#define got_ipv6(x) (x->jail_flags & (GOT_IPV6))
> +#define set_ipv4(x) (x->jail_flags |= GOT_IPV4)
> +#define set_ipv6(x) (x->jail_flags |= GOT_IPV6)
> +#define unset_got_ipv4(x) (x->jail_flags &= ~GOT_IPV4)
> +#define unset_got_ipv6(x) (x->jail_flags &= ~GOT_IPV6)
> +
> +#define get_task_security(task) (task->security)
> +#define get_inode_security(inode) (inode->i_security)
> +#define get_sock_security(sock) (sock->sk_security)
> +#define get_file_security(file) (file->f_security)
> +#define get_ipc_security(ipc)	(ipc->security)
> +
> +#define jail_of(proc) (get_task_security(proc))
> +
> +#define set_task_security(task,data) task->security = data
> +#define set_inode_security(inode,data) inode->i_security = data
> +#define set_sock_security(sock,data) sock->sk_security = data
> +#define set_file_security(file,data) file->f_security = data
> +#define set_ipc_security(ipc,data)   ipc.security = data

Hi Serge,

Do you really need all thoses macros ?
It seems to me that's too much macros for stuff which are easy
to write and to understand.

Just my 2cents,
-- 
Tab
