From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [GIT PULL] Please Pull Mellanox Shared Code
Date: Tue, 14 Jun 2016 20:34:19 +0300
Message-ID: <CAJ3xEMi3jgkzXMZ52Vu=6JAS=HbVXWPiNJUWrkjJdpqQ2hAKqg@mail.gmail.com>
References: <20160613120301.GF5408@leon.nu> <20160614063548.GN5408@leon.nu>
 <20160614.030229.1431969399873476358.davem@davemloft.net> <e88d3000-f137-181e-4ea2-cd33101dd57c@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	"linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Matan Barak <matanb@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Leon Romanovsky <leonro@mellanox.com>
To: Doug Ledford <dledford@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f52.google.com ([209.85.218.52]:34270 "EHLO
	mail-oi0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751364AbcFNRe0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jun 2016 13:34:26 -0400
In-Reply-To: <e88d3000-f137-181e-4ea2-cd33101dd57c@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 14, 2016 at 8:16 PM, Doug Ledford <dledford@redhat.com> wrote:

> Dave,
>
> He's doing what Linus requested from Mellanox.  They were instructed to
> identify all of the coming changes in the next release where patches
> sent through your tree and patches sent through my tree would have
> conflicts.  They were then instructed to make git commits that merged
> those changes and have both you and I pull them (please note "pull", not
> git am patches) so that we have the exact same commit hashes in our
> trees and git will do the right thing when your tree and my tree are
> merged in the next merge window.  As it turns out the conflicts are
> mainly in this firmware offset definition file.  They just put all of
> the needed changes in there in one commit.  I doubt they have individual
> patches here.

Doug,

The main comment was that the submission lacked posting of the actual
changes inline as patch/es along with a cover letter that gives the
background plus the URL for git pulling of this. In this case (4.8
shared code), the submission only touches the mlx5_ifc.c FW file and
indeed it makes sense to have only one patch that covers it all, in
prev/future cases we had/would have that in multiple patches.

Leon re-submitted that later today in the proper way

Or.

> This was a custom made patch who's sole purpose is to
> combine all the otherwise possibly conflicting changes in one place.
> I'm sure they could split it out into different commits, but they
> wouldn't be full commits, just the portion that applies to this firmware file
