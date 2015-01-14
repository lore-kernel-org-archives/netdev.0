From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [net-next PATCH v2 02/12] net: flow_table: add flow, delete flow
Date: Wed, 14 Jan 2015 19:50:56 +0000
Message-ID: <20150114195056.GD2105@casper.infradead.org>
References: <20150113212941.13874.48692.stgit@nitbit.x32>
 <20150113213556.13874.41211.stgit@nitbit.x32>
 <CAADnVQK0FqxD9iu5UzFu0Pizi9tQPgjmAs3WBbV7y8jk0Sdi5w@mail.gmail.com>
 <54B68349.3080603@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	simon.horman@netronome.com, Scott Feldman <sfeldma@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gerlitz.or@gmail.com" <gerlitz.or@gmail.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	"David S. Miller" <davem@davemloft.net>
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:32891 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753615AbbANTu6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jan 2015 14:50:58 -0500
Content-Disposition: inline
In-Reply-To: <54B68349.3080603@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/14/15 at 06:55am, John Fastabend wrote:
> If one of the actions supported by the device is forward_to_queue() or
> forward_to_socket() we can use the API to steer potentially interesting
> packets to a user space application for processing.

+1

Ideally using NFQUEUE so we can leverage existing infrastructure.
