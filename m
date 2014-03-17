From: Or Gerlitz <or.gerlitz@gmail.com>
Subject: Re: [net-next 03/16] i40evf: Support RSS option in ethtool
Date: Mon, 17 Mar 2014 23:19:25 +0200
Message-ID: <CAJZOPZKpv-d-pPA6OuUMqcvZDa+ZM2rrLYBpOnaojfa6UYZLWg@mail.gmail.com>
References: <1395060316-16897-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<1395060316-16897-4-git-send-email-jeffrey.t.kirsher@intel.com>
	<CAJZOPZJWCDGcC3hWAVsLkN8LSY-7GifDSKN6OhDRjgwFpjtuSw@mail.gmail.com>
	<AAEA33E297BCAC4B9BB20A7C2DF0AB8D6556FAE5@FMSMSX113.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>,
	"Sullivan, Catherine" <catherine.sullivan@intel.com>
To: "Williams, Mitch A" <mitch.a.williams@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f179.google.com ([209.85.192.179]:33267 "EHLO
	mail-pd0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750866AbaCQVT0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Mar 2014 17:19:26 -0400
Received: by mail-pd0-f179.google.com with SMTP id w10so6104428pde.38
        for <netdev@vger.kernel.org>; Mon, 17 Mar 2014 14:19:25 -0700 (PDT)
In-Reply-To: <AAEA33E297BCAC4B9BB20A7C2DF0AB8D6556FAE5@FMSMSX113.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 17, 2014 at 8:55 PM, Williams, Mitch A
<mitch.a.williams@intel.com> wrote:
>> On Mon, Mar 17, 2014 at 2:45 PM, Jeff Kirsher
>> <jeffrey.t.kirsher@intel.com> wrote:
>> > From: Mitch Williams <mitch.a.williams@intel.com>
>> >
>> > Add support for viewing and modifying RSS hash options and RSS hash
>> > look-up table programming through ethtool.
>> [...]
>>
>> FWIW, this commit does more... wouldn't it be worth dropping some
>> words on that on that change-log?
>>
>
> Well, Or, I'm not sure really what to say. I added code to change which hashing options RSS would use, and code to change the RSS lookup table.
>
> Looks like Ben has some comments, so we'll have to respin this anyway. I'm happy to change the description, just wondering what you'd like to see here.

When I made the comment I saw that you added bunch of ethtool calls
and wasn't sure this is covered in the change log, in 2nd look I see
one entry which isn't mentioned and isn't directly related to RSS, the
one that gets the number of channels, but it's minor and I assume can
stay here, maybe even non mentioned in the change log, but that will
be according to your taste


>
> -Mitch
>
>> [...]
>> >  static struct ethtool_ops i40evf_ethtool_ops = {
>> >         .get_settings           = i40evf_get_settings,
>> >         .get_drvinfo            = i40evf_get_drvinfo,
>> > @@ -378,6 +687,12 @@ static struct ethtool_ops i40evf_ethtool_ops = {
>> >         .set_msglevel           = i40evf_set_msglevel,
>> >         .get_coalesce           = i40evf_get_coalesce,
>> >         .set_coalesce           = i40evf_set_coalesce,
>> > +       .get_rxnfc              = i40evf_get_rxnfc,
>> > +       .set_rxnfc              = i40evf_set_rxnfc,
>> > +       .get_rxfh_indir_size    = i40evf_get_rxfh_indir_size,
>> > +       .get_rxfh_indir         = i40evf_get_rxfh_indir,
>> > +       .set_rxfh_indir         = i40evf_set_rxfh_indir,
>> > +       .get_channels           = i40evf_get_channels,
>> >  };
