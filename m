From: Roger Luethi <rl@hellgate.ch>
Subject: Re: [RFC] ethtool semantics
Date: Tue, 8 Jun 2004 23:08:09 +0200
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <20040608210809.GA10542@k3.hellgate.ch>
References: <20040607212804.GA17012@k3.hellgate.ch> <20040607145723.41da5783.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jgarzik@pobox.com, netdev@oss.sgi.com, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org-S265359AbUFHVRq@vger.kernel.org>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
In-Reply-To: <20040607145723.41da5783.davem@redhat.com>
List-Id: netdev.vger.kernel.org

On Mon, 07 Jun 2004 14:57:23 -0700, David S. Miller wrote:
> On Mon, 7 Jun 2004 23:28:04 +0200
> Roger Luethi <rl@hellgate.ch> wrote:
> 
> > What is the correct response if a user passes ethtool speed or duplex
> > arguments while autoneg is on? Some possible answers are:
> > 
[...]
> speed and duplex fields should be silently ignored in this case

It may not matter much because few people care about forced media these
days. And it is debatable whether trying to guess the users intention
is a good idea (we lack means for users to manipulate autoneg results
via advertisted values but that's no big deal).

However, "silently ignoring" strikes me as a very poor choice, in
stark contrast to Unix/Linux tradition. A user issues a command which
cannot be executed and gets the same response that is used to indicate
success!? What school of user interface design is that? How is that
not confusing users? </rant>

Roger
