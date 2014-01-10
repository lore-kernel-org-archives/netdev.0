From: Joe Perches <joe@perches.com>
Subject: Re: [net-next 05/16] i40e: fix long lines
Date: Fri, 10 Jan 2014 02:35:38 -0800
Message-ID: <1389350138.2537.3.camel@joe-AO722>
References: <1389344336-1558-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1389344336-1558-6-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1389344869.24222.31.camel@joe-AO722>
	 <063D6719AE5E284EB5DD2968C1650D6D457950@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	Mitch Williams <mitch.a.williams@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0005.hostedemail.com ([216.40.44.5]:48499 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751013AbaAJKfm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jan 2014 05:35:42 -0500
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D457950@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2014-01-10 at 10:02 +0000, David Laight wrote:
> > Another way this could be changed is to put the
> > return value on a separate line like:
> > 
> > i40e_status
> > i40e_aq_set_vsi_unicast_promiscuous(struct i40e_hw *hw, u16 seid, bool set,
> > 				    struct i40e_asq_cmd_details *cmd_details)
> 
> Personally I prefer that so I can find the definition by grepping
> for '^function_name' - but it doesn't seem to be done in any linux
> source files.

That form is used in a lot of files.
$ git grep -E "^[a-z_]+\("
