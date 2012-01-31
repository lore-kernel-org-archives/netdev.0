From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH 22/29] sysctl: Stop requiring explicit management of sysctl directories
Date: Mon, 30 Jan 2012 20:45:02 -0800
Message-ID: <m162fsbhv5.fsf@fess.ebiederm.org>
References: <m1pqe5ah3z.fsf@fess.ebiederm.org>
	<1327639925-12920-22-git-send-email-ebiederm@xmission.com>
	<CAPLs8y8smiRj_Xbtme3v165CuyJOnJpA_pJNwdCMLWb2M1-e8A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	netdev@vger.kernel.org,
	Damien Millescamps <damien.millescamps@6wind.com>
To: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAPLs8y8smiRj_Xbtme3v165CuyJOnJpA_pJNwdCMLWb2M1-e8A@mail.gmail.com>
	(Lucian Adrian Grijincu's message of "Sun, 29 Jan 2012 21:31:41
	+0200")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Lucian Adrian Grijincu <lucian.grijincu@gmail.com> writes:

>
> Why do you only check the given @set after creating the new dir. Why
> not the parent dir too?

That is a race and a minor bug.  Somehow I had convinced myself that
either it didn't matter or that it would be hard to deal with, but
that doesn't hold up.  Oops.  Thankfully the final version using links
does not have this race/bug. 

Eric
