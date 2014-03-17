From: "Williams, Mitch A" <mitch.a.williams@intel.com>
Subject: RE: [net-next 01/16] i40e: support VF link state ndo
Date: Mon, 17 Mar 2014 21:40:17 +0000
Message-ID: <AAEA33E297BCAC4B9BB20A7C2DF0AB8D65571229@FMSMSX113.amr.corp.intel.com>
References: <1395060316-16897-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<1395060316-16897-2-git-send-email-jeffrey.t.kirsher@intel.com>
 <CAJZOPZLrwg2sMnhQZZhpjWdqjBEBuWujv0Uy9q-_bViK5j46zg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>,
	"Sullivan, Catherine" <catherine.sullivan@intel.com>
To: Or Gerlitz <or.gerlitz@gmail.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:6136 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752107AbaCQVk5 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Mar 2014 17:40:57 -0400
In-Reply-To: <CAJZOPZLrwg2sMnhQZZhpjWdqjBEBuWujv0Uy9q-_bViK5j46zg@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> -----Original Message-----
> From: Or Gerlitz [mailto:or.gerlitz@gmail.com]
> Sent: Monday, March 17, 2014 2:24 PM
> To: Kirsher, Jeffrey T
> Cc: David Miller; Williams, Mitch A; netdev@vger.kernel.org;
> gospo@redhat.com; sassmann@redhat.com; Sullivan, Catherine
> Subject: Re: [net-next 01/16] i40e: support VF link state ndo
> 
> On Mon, Mar 17, 2014 at 2:45 PM, Jeff Kirsher
> <jeffrey.t.kirsher@intel.com> wrote:
> > From: Mitch Williams <mitch.a.williams@intel.com>
> > This netdev op allows the PF driver to control the virtual link state of
> > the VF devices. This can be used to deny naughty VF drivers access to the
> wire,
> 
> Does this denial exists in the patch or the current code? where?
> 
> Or.

To clarify: you can manually deny link to a VF with this functionality. This would not automatically find and shut down misbehaving VFs. That functionality is planned but is not yet ready, and would operate on the hardware level.

-Mitch
