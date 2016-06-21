From: Hannes Frederic Sowa <hannes@redhat.com>
Subject: Re: [net-next PATCH v3 00/17] Future-proof tunnel offload handlers
Date: Tue, 21 Jun 2016 14:34:35 -0700
Message-ID: <e0bf4896-d394-b1d0-1a0d-4affc3b0df4a@redhat.com>
References: <20160616191851.20872.67154.stgit@localhost.localdomain>
 <20160617.202641.1821023739498595024.davem@davemloft.net>
 <CALx6S34Y3Qq6nMHuMcC2LC5duLBO3KVN3+A+0qmPrNvFfY7gJg@mail.gmail.com>
 <20160621.042211.945844554759834352.davem@davemloft.net>
 <CAKgT0Ucze-+PYdvoHhDSLuaTLrn+Ene+CnfJaKO7AEHGHBsKzg@mail.gmail.com>
 <18b4d172-2cf5-8246-9cac-ce92adf65bc8@solarflare.com>
 <234d6a2f-6971-7029-0645-f98e51236c4f@redhat.com>
 <CAKgT0UdsYo84J087KUTiiwuHGUaykPvpQTVxCdvE9k21tM5hsQ@mail.gmail.com>
 <CALx6S34EXpxA5fs+HDUczMHaAD5q_yQMRVvwhCbSJCBO8_PRuQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Edward Cree <ecree@solarflare.com>,
	David Miller <davem@davemloft.net>,
	Alex Duyck <aduyck@mirantis.com>,
	Netdev <netdev@vger.kernel.org>,
	intel-wired-lan <intel-wired-lan@lists.osuosl.org>,
	Jesse Gross <jesse@kernel.org>,
	Eugenia Emantayev <eugenia@mellanox.com>,
	Jiri Benc <jbenc@redhat.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Ariel Elior <ariel.elior@qlogic.com>,
	Michael Chan <michael.chan@broadcom.com>,
	Dept-GELinuxNICDev@qlogic.com
To: Tom Herbert <tom@herbertland.com>,
	Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56182 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751549AbcFUVen (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Jun 2016 17:34:43 -0400
In-Reply-To: <CALx6S34EXpxA5fs+HDUczMHaAD5q_yQMRVvwhCbSJCBO8_PRuQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 21.06.2016 11:42, Tom Herbert wrote:
>> > There is also some argument to be had for theory versus application.
>> > Arguably it is the customers that are leading to some of the dirty
>> > hacks as I think vendors are building NICs based on customer use cases
>> > versus following any specifications.  In most data centers the tunnel
>> > underlays will be deployed throughout the network and UDP will likely
>> > be blocked for anything that isn't being used explicitly for
>> > tunneling.  As such we seem to be seeing a lot of NICs that are only
>> > supporting one port for things like this instead of designing them to
>> > handle whatever we can throw at them.
>> >
> Actually, I don't believe that's true. It is not typical to deploy
> firewalls within a data center fabric, and nor do we restrict
> applications from binding to any UDP ports and they can pretty much
> transmit to any port on any host without cost using an unconnected UDP
> socket. I think it's more likely that NIC (and switch vendors) simply
> assumed that port numbers can be treated as global values. That's
> expedient and at small scale we can probably get away with it, but at
> large scale this will eventually bite someone.

I do have access to relatively normal expensive switches that can
basically be used to realize a scenario like the one Alex described. No
firewalls necessary. If you can guarantee that your customers never have
access to your hypervisors or container management namespace, this is
actually a pretty solid assumption.

Bye,
Hannes
