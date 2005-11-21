From: "Christopher Friesen" <cfriesen@nortel.com>
Subject: Re: netlink nlmsg_pid supposed to be pid or tid?
Date: Mon, 21 Nov 2005 13:46:21 -0600
Message-ID: <4382240D.4000507@nortel.com>
References: <438220C3.4040602@nortel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932410AbVKUTqm@vger.kernel.org>
To: netdev@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
In-Reply-To: <438220C3.4040602@nortel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Friesen, Christopher [CAR:VC21:EXCH] wrote:
> 
> When using netlink, should "nlmsg_pid" be set to pid (current->tgid) or 
> tid (current->pid)?

The reason I ask is that with 2.6.10 we had to set it to tid, which 
really doesn't make much sense given than sockets are shared across all 
threads in a process (and gettid() isn't even a libc function).

Chris
