From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 5/6] e1000 driver remove checkpatch errors, warnings and
 checks.
Date: Tue, 13 Oct 2015 18:18:06 -0700
Message-ID: <1444785486.9184.40.camel@perches.com>
References: <1444772362-25090-1-git-send-email-januszwolak@awokados.com.pl>
	 <1444772362-25090-5-git-send-email-januszwolak@awokados.com.pl>
	 <561D846E.1050405@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Janusz Wolak <januszwolak@awokados.com.pl>,
	jeffrey.t.kirsher@intel.com, jesse.brandeburg@intel.com,
	shannon.nelson@intel.com, carolyn.wyborny@intel.com,
	donald.c.skidmore@intel.com, matthew.vick@intel.com,
	john.ronciak@intel.com, mitch.a.williams@intel.com,
	intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Janusz Wolak <januszvdm@gmail.com>
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <561D846E.1050405@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2015-10-13 at 15:23 -0700, Alexander Duyck wrote:
> Please don't just blindly 
> follow checkpatch as it can give out erroneous information.
> 
> Looking over most of this patch series it seems like it is taking 
> readability in the wrong direction and reducing the ability to maintain 
> the driver since this code has been "maintenance only" for some time 
> now.  If somebody comes up with a legitimate fix for an issue at some 
> point in the future they will need to work around these patches in order 
> to back-port it into a stable release and that just hurts maintainability.
> 
> I'd say this whole series should be rejected on the grounds that this 
> driver is mostly stable and should only really be modified for bug fixes 
> at this point.  If we really need to go through and do a checkpatch 
> sweep we should probably just focus on serious errors only instead of 
> going astray and chasing down things that are false hits or minor issues 
> that are mostly a matter of preference.

Excellent advice.
