From: "Randy.Dunlap" <rddunlap@osdl.org>
Subject: Re: patches for PROC_FS=n (2.6.0-test7)
Date: Mon, 13 Oct 2003 07:49:29 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031013074929.0edb73be.rddunlap@osdl.org>
References: <20031012201316.7ecf73c8.rddunlap@osdl.org>
	<Pine.LNX.4.44.0310131328400.21697-100000@server>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: noah@caltech.edu, netdev@oss.sgi.com, davem@redhat.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Elmer <elmer@linking.ee>
In-Reply-To: <Pine.LNX.4.44.0310131328400.21697-100000@server>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 13 Oct 2003 13:31:30 +0200 (EET) Elmer <elmer@linking.ee> wrote:

| 
| 
| arlan.c is ok without arlan-proc.c
| as init_arlan_proc is in arlan-proc.c, it shoult be
| OK, as long as radio parameters are saved into cards ROM.
| 
| I have forgot a lot about that code, of course.

Hi Elmer,
Sure, I understand the last comment.

I don't quite understand the first paragraph though.
Could we try again?

Currently arlan.c + arlan-proc.c does not build if CONFIG_PROC_FS=n.
The Makefile always builds arlan-main.o and arlan-proc.o.
Are you saying that this is incorrect?
Should arlan-proc.o only be built/used when CONFIG_PROC_FS=y?

Thanks.
--
~Randy
