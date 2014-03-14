From: Peter Hurley <peter@hurleysoftware.com>
Subject: Re: pppd service crash in linux-3.13.6
Date: Fri, 14 Mar 2014 11:02:04 -0400
Message-ID: <532319EC.8000509@hurleysoftware.com>
References: <531A37FF.4000509@totakura.in> <531DEEA6.4090808@totakura.in> <531E111A.8040207@hurleysoftware.com> <20140313170622.GA31206@redhat.com> <5321F113.7090000@hurleysoftware.com> <53230FE5.9020204@hurleysoftware.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Sree Harsha Totakura <sreeharsha@totakura.in>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: Oleg Nesterov <oleg@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <53230FE5.9020204@hurleysoftware.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 03/14/2014 10:19 AM, Peter Hurley wrote:
> Plus, proc_exit_connector() uses netlink which uses user_ns.

Actually, I think this can be safely ignored since if the
netlink socket was tied to a user_ns which has just been
freed in exit_task_namespace() then the socket could not
be open in another process (otherwise the net_ns would
still have an open reference).
