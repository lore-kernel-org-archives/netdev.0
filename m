From: "David S. Miller" <davem@redhat.com>
Subject: Re: Tigon3 5701 PCI-X recv performance problem
Date: Wed, 8 Oct 2003 12:15:24 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031008121524.2faa23c4.davem@redhat.com>
References: <3F844578.40306@sgi.com>
	<20031008101046.376abc3b.davem@redhat.com>
	<3F844EF9.9090901@sgi.com>
	<20031008112657.2adddeb6.davem@redhat.com>
	<3F845F61.9080002@sgi.com>
	<3F846173.9090107@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: johnip@sgi.com, netdev@oss.sgi.com, jgarzik@pobox.com, jes@sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Steve Modica <modica@sgi.com>
In-Reply-To: <3F846173.9090107@sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 08 Oct 2003 14:11:47 -0500
Steve Modica <modica@sgi.com> wrote:

> I think it'd be better to create some macro like this:

Please, do this right.  Make a "CONFIG_UNALIGNED_VERY_SLOW"
or something that platforms can define, and then drivers can
ifdef upon.
