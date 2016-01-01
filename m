From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: net-i40e: Reconsider further usage of variable "i" in
 i40e_vc_get_vf_resources_msg()
Date: Fri, 1 Jan 2016 15:51:11 +0100
Message-ID: <5686925F.5020508@users.sourceforge.net>
References: <566ABCD9.1060404@users.sourceforge.net>
 <56868E0B.5040602@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: kernel-janitors@vger.kernel.org
To: netdev@vger.kernel.org, intel-wired-lan@lists.osuosl.org,
	Bruce Allan <bruce.w.allan@intel.com>,
	Carolyn Wyborny <carolyn.wyborny@intel.com>,
	Don Skidmore <donald.c.skidmore@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	Mitch Williams <mitch.a.williams@intel.com>,
	Shannon Nelson <shannon.nelson@intel.com>
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <56868E0B.5040602@users.sourceforge.net>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

I have taken another look at the implementation of the
function "i40e_vc_get_vf_resources_msg". I find the use of the variable "i"
strange there. It seems that the value from the increment operation in an
if branch is not reused so far.

I would appreciate a further clarification.
Can this variable be eventually deleted?

Regards,
Markus
