From: Sridhar Samudrala <sri@us.ibm.com>
Subject: Re: [BK PATCH] 2.6.2 SCTP updates
Date: Mon, 9 Feb 2004 12:01:20 -0800 (PST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.58.0402091155070.10043@localhost.localdomain>
References: <Pine.LNX.4.58.0402061649001.10831@localhost.localdomain>
 <20040206194518.56787717.davem@redhat.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20040206194518.56787717.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, 8 Feb 2004, David S. Miller wrote:

> On Sun, 8 Feb 2004 09:07:48 -0800 (PST)
> Sridhar Samudrala <sri@us.ibm.com> wrote:
>
> > I guess i was influenced by the TCP specific tcp_rmem/tcp_wmem. But TCP
> > seems to be using them as a vector of 3 values and tuning the buffer sizes
> > dynamically based on these values.
> > As of now, SCTP doesn't do any tuning dynamically so i could have used the
> > core rmem_default/wmem_default.
> >
> > Do you want me to remove the specialized SCTP sysctl's?
>
> It seems as duplication if there is no specific need to have seperate
> controls right?

OK. I removed the SCTP specific rmem/wmem. Please do a pull again from
	http://linux-lksctp.bkbits.net/lksctp-2.5.work
to get the following cset.

ChangeSet@1.1551, 2004-02-09 11:14:24-08:00, sri@us.ibm.com
  [SCTP] Removed SCTP specific rmem/wmem sysctl's and use the global
         rmem_default/wmem_default values for SCTP socket buffer sizes.

Thanks
Sridhar
