From: "David S. Miller" <davem@davemloft.net>
Subject: Re: udp_poll breaks vpnc
Date: Wed, 15 Dec 2004 13:14:05 -0800
Message-ID: <20041215131405.7f5308a5.davem@davemloft.net>
References: <20041215131342.21768388@lembas.zaitcev.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, zaitcev@redhat.com, linux-kernel@vger.kernel.org,
        shemminger@osdl.org, davem@redhat.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Pete Zaitcev <zaitcev@redhat.com>
In-Reply-To: <20041215131342.21768388@lembas.zaitcev.lan>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 15 Dec 2004 13:13:42 -0800
Pete Zaitcev <zaitcev@redhat.com> wrote:

> I found that the attached patch breaks VPNC. By looking at strace, it never
> gets any poll events about arriving encrypted data. It may be a bug in VPNC,
> but this is a rather old binary which I used even on 2.4...

Fixed by a followon patch which is in BK as of 2 weeks ago.
Basically, we were using UDP poll for RAW sockets by accident.
