From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next v7 1/2] bpf: Add bpf_probe_write_user BPF helper
 to be called in tracers
Date: Mon, 25 Jul 2016 15:16:55 +0200
Message-ID: <57961147.3090101@iogearbox.net>
References: <20160725125444.GA15051@ircssh.c.rugged-nimbus-611.internal>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: alexei.starovoitov@gmail.com
To: Sargun Dhillon <sargun@sargun.me>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160725125444.GA15051@ircssh.c.rugged-nimbus-611.internal>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 07/25/2016 02:54 PM, Sargun Dhillon wrote:
> This allows user memory to be written to during the course of a kprobe.
> It shouldn't be used to implement any kind of security mechanism
> because of TOC-TOU attacks, but rather to debug, divert, and
> manipulate execution of semi-cooperative processes.
>
[...]

v7 looks good to me now as well, thanks a bunch Sargun!
