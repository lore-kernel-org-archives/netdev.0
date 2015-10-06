From: Jon Ringle <jonringle@gmail.com>
Subject: Re: [PATCH 1/2] regmap: only call custom reg_update_bits() if reg is marked volatile
Date: Tue, 6 Oct 2015 08:50:43 -0400
Message-ID: <ABC562FD-5DE5-452E-8DE6-1C436E37E8BE@gmail.com>
References: <1444051772-20270-1-git-send-email-jon@ringle.org> <20151005145722.GT12635@sirena.org.uk> <20151005.232956.105884641412802470.davem@davemloft.net> <20151006101305.GG12635@sirena.org.uk>
Mime-Version: 1.0 (1.0)
Content-Type: text/plain;
	charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	"jon@ringle.org" <jon@ringle.org>,
	"gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"jringle@gridpoint.com" <jringle@gridpoint.com>
To: Mark Brown <broonie@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f173.google.com ([209.85.160.173]:33607 "EHLO
	mail-yk0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751727AbbJFMuq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Oct 2015 08:50:46 -0400
In-Reply-To: <20151006101305.GG12635@sirena.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> On Oct 6, 2015, at 6:13 AM, Mark Brown <broonie@kernel.org> wrote:
> 
>> On Mon, Oct 05, 2015 at 11:29:56PM -0700, David Miller wrote:
>> From: Mark Brown <broonie@kernel.org>
> 
>>> Dave, to be clear please do *not* apply this patch at least for the time
>>> being - I've not reviewed it or the one from Thursday that you applied
>>> this morning.
> 
>> It's applied, it's pushed out to my tree, and therefore this will need to
>> be fixed up with a relative patch of some sort.
> 
> This appears to be an incremental change, not the initial commit which
> you already applied.  I'm asking you to stop applying changes to regmap
> which have not been reviewed.
> 
>> What you don't seem to understand is that my GIT tree is never rebased
>> or mangled because many people depend upon it.  So once a patch is
>> applied, that commit lives on forever.
> 
> I'm not *so* concerned if the patch lives in history, I'm concerned with
> having something I can sensibly review and ideally getting the code into
> my tree.

I would suggest the following course of action:

1) David, revert the following from net-next:
$ git revert 9886ce2b9d4e5a8bb3d78d0f7eff3c0f1ed58d67
$ git revert 04fbfce7a222327b97ca165294ef19f0faa45960
$ git revert 7741c373cf3ea1f5383fa97fb7a640a429d3dd7c

2) Mark, please use the patch titled "[PATCH net-next v3 1/2] regmap:
Allow installing custom". It will apply cleanly to the regmap for-next
branch
3) Once Mark has accepted this patch into the regmap tree, I will make
any adjustments needed to the net-next patch.
4) David should then merge the regmap for-next branch into net-next
5) I will submit a new patch to net-next for the encx24j600 driver
that should build against the regmap changes

Sound like a good plan?

-Jon
