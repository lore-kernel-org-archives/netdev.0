From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH 2/2] Prefix List and O/M flags against 2.4.21
Date: Sun, 20 Jul 2003 21:46:53 -0700
Sender: linux-net-owner@vger.kernel.org
Message-ID: <20030720214653.2de7ce82.davem@redhat.com>
References: <3F17245D.9040806@us.ibm.com>
	<200307210155.FAA31320@dub.inr.ac.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: krkumar@us.ibm.com, yoshfuji@linux-ipv6.org, netdev@oss.sgi.com,
	linux-net@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
To: kuznet@ms2.inr.ac.ru
In-Reply-To: <200307210155.FAA31320@dub.inr.ac.ru>
List-Id: netdev.vger.kernel.org

On Mon, 21 Jul 2003 05:55:04 +0400 (MSD)
kuznet@ms2.inr.ac.ru wrote:

> The patch is not quite complete: except for those two questions,
> I forgot to add MTU truncated to its IPv4 value, did nothing
> for multicast things (I still cannot figure out, what information is
> really useful) and did not add active notifications which would be good
> to be made after sysctl parameters are changed.

Please let us to use some portable types instead of
'int' :-)  It is just minor nit, I otherwise like the
whole idea.

Why are we limited to arrays of 'u32' or whatever?  RTA_PUT() can
place arbitrary things into the message and length is given.
