From: Junio C Hamano <junio@pobox.com>
Subject: Re: [PATCH 2/2] cxgb3 - Parity initialization for T3C adapters
Date: Tue, 11 Dec 2007 14:27:55 -0800
Message-ID: <7vbq8wdfys.fsf@gitster.siamese.dyndns.org>
References: <20071205181527.22106.73134.stgit@speedy5>
	<4759A6EA.1050106@garzik.org> <4759CD92.2070604@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, swise@opengridcomputing.com,
	wenxiong@us.ibm.com
To: Divy Le Ray <divy@chelsio.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755990AbXLKWgv@vger.kernel.org>
In-Reply-To: <4759CD92.2070604@chelsio.com> (Divy Le Ray's message of "Fri, 07
	Dec 2007 14:47:46 -0800")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Divy Le Ray <divy@chelsio.com> writes:

> On this topic, I have a question: how do I get to see all the
> netdev-2.6 branches ?
> After cloning a free  netdev-2.6 tree, 'git branch' shows only the
> master branch:
> ...
> Cloning
> "git://git.kernel.org/pub/scm/linux/kernel/git/jgarzik/netdev-2.6.git"
> into "netdev-2.6-fresh"...
> Initialized empty Git repository in /opt/sources/netdev-2.6-fresh/.git/
> ...
> 100% (23058/23058) done
> done
> -bash-3.1$ cd netdev-2.6-fresh/
> -bash-3.1$ git branch
> * master

At this point,

$ git branch -r

will show you have copies of Jeff's branches in remotes/origin/.

$ git checkout -b upstream origin/upstream

would make your local upstream branch that forks from Jeff's upstream
branch.
