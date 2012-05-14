From: Jan Engelhardt <jengelh@inai.de>
Subject: Re: [PATCH] netfilter: xt_HMARK: endian bugs
Date: Mon, 14 May 2012 20:24:53 +0200 (CEST)
Message-ID: <alpine.LNX.2.01.1205142015310.22219@frira.vanv.qr>
References: <1337002943-16374-1-git-send-email-hans.schillstrom@ericsson.com> <201205141809.18174.hans.schillstrom@ericsson.com> <1337012674.8512.589.camel@edumazet-glaptop> <201205141951.36692.hans.schillstrom@ericsson.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	"kaber@trash.net" <kaber@trash.net>,
	"jengelh@medozas.de" <jengelh@medozas.de>,
	"netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"dan.carpenter@oracle.com" <dan.carpenter@oracle.com>,
	"hans@schillstrom.com" <hans@schillstrom.com>
To: Hans Schillstrom <hans.schillstrom@ericsson.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <201205141951.36692.hans.schillstrom@ericsson.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Monday 2012-05-14 19:51, Hans Schillstrom wrote:

>On Monday 14 May 2012 18:24:34 Eric Dumazet wrote:
>> On Mon, 2012-05-14 at 18:09 +0200, Hans Schillstrom wrote:
>> 
>> > This context can contain both le & be machines,
>> > so at least in hmark it make sense
>> 
>> Before jhash() and its shuffle ? What do you mean ?
>
>I want that a Big endian machine should produce the same
>hash value independent of flow direction as a Little endian.

But one does not really need that, since the hash is only used locally.
