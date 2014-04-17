From: Vivek Goyal <vgoyal@redhat.com>
Subject: Re: [PATCH 2/2] net: Implement SO_PASSCGROUP to enable passing
 cgroup path
Date: Thu, 17 Apr 2014 09:41:23 -0400
Message-ID: <20140417134123.GA15749@redhat.com>
References: <1397664837.19767.410.camel@willson.li.ssimo.org>
 <CALCETrXn7b6UuALpGUVoyQYfR2uzk5tj2ABV=dkvtFNgqM5sxQ@mail.gmail.com>
 <20140416180642.GG31074@redhat.com>
 <CALCETrVUw5+vCCONy1VTXpskbY_eZFo2CtbehwV5Mhj4d4+icw@mail.gmail.com>
 <20140416182530.GB550@redhat.com>
 <CALCETrUs1js3Br81ZkiQnsuWduzOiqDe3aV0K_z_zw0znSuiag@mail.gmail.com>
 <20140416190657.GK31074@redhat.com>
 <CALCETrUv56awd+UoO_f8LLL2FVq-Hc6Bd6iBGMqWjVGpgxgTSg@mail.gmail.com>
 <20140416193918.GM31074@redhat.com>
 <CALCETrU9P+1Az+uuU_zE4uZZ-qmp5M_=YAXvfcK=rzQRbgoG5g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Simo Sorce <ssorce@redhat.com>, David Miller <davem@davemloft.net>,
	Tejun Heo <tj@kernel.org>, Daniel Walsh <dwalsh@redhat.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	lpoetter@redhat.com, cgroups@vger.kernel.org, kay@redhat.com,
	Network Development <netdev@vger.kernel.org>
To: Andy Lutomirski <luto@amacapital.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CALCETrU9P+1Az+uuU_zE4uZZ-qmp5M_=YAXvfcK=rzQRbgoG5g@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Apr 16, 2014 at 01:24:32PM -0700, Andy Lutomirski wrote:

[..]
> I'm not talking about the risk that someone learns someone's cgroup.
> I'm talking about the risk that a malicious program can get a lot
> entry like: "whatever planted text"
> _SYSTEMD_UNIT=non-malicious.service.  That is, they've spoofed a log
> line.
> 
> If you don't care about spoofing of log lines, then there's no point
> to having the kernel validate them anyway.

What's wrong with this. A message came from a cgroup which maps to
a unit xyz and it got logged.  I can't see what's wrong here.

Anyway that message will get logged with unit information. These patches
will just make getting unit information race free and more reliable.

Thansk
Vivek
