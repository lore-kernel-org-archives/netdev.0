From: David Brownell <david-b@pacbell.net>
Subject: Re: Patch: Idea for RFC2863 conform OperStatus
Date: Mon, 14 Oct 2002 12:03:56 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3DAB151C.3030806@pacbell.net>
References: <Pine.GSO.4.30.0210140918170.26803-100000@shell.cyberus.ca>
 <3DAB0982.C0C6E36F@isg.de> <3DAB1305.10805@pacbell.net>
Mime-Version: 1.0
Content-Type: text/plain; format=flowed; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stefan Rompf <srompf@isg.de>, jamal <hadi@cyberus.ca>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


> Right now almost all USB networking drivers make the device disappear
> immediately ... certainly the ones that have made sure they handle the
> USB disconnect processing correctly (no more I/O to that device!) tend
> to do that, by calling unregister_netdev().

... which would let Linux implement a NotPresent(ifname) test
just by seeing if it's registered, unless that RFC demands some
more abstruse meaning.  (I've not read it lately.)
