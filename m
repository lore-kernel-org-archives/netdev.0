From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: Re: [RFC v2 00/10] snet: Security for NETwork syscalls
Date: Sun, 7 Mar 2010 14:47:56 +0900
Message-ID: <201003071447.IAH35984.OJVFLOtQFFOSHM@I-love.SAKURA.ne.jp>
References: <1267561394-13626-1-git-send-email-sam@synack.fr>
	<201003030156.o231udx1023055@www262.sakura.ne.jp>
	<m2zl2lpa4d.fsf@ssh.synack.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org, hadi@cyberus.ca, kaber@trash.net,
	zbr@ioremap.net, nhorman@tuxdriver.com, root@localdomain.pl,
	linux-security-module@vger.kernel.org, serue@us.ibm.com
To: sam@synack.fr
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <m2zl2lpa4d.fsf@ssh.synack.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Samir Bellabes wrote:
> Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp> writes:
> 
> > Regarding [RFC v2 02/10] Revert "lsm: Remove the socket_post_accept() hook"
> > @@ -1538,6 +1538,8 @@ SYSCALL_DEFINE4(accept4, int, fd, struct sockaddr __user *, upeer_sockaddr,
> >  	fd_install(newfd, newfile);
> >  	err = newfd;
> >  
> > +	security_socket_post_accept(sock, newsock);
> > +
> >  out_put:
> >  	fput_light(sock->file, fput_needed);
> >  out:
> >
> > Please move security_socket_post_accept() to before fd_install().
> > Otherwise, other threads which share fd tables can use
> > security-informations-not-yet-updated accept()ed sockets.
> 
> Tetsuo, what about this patch ?
> 
Looks OK to me. Thanks.
