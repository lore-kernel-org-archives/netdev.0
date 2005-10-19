From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [patch 2.6.14-rc4 0/3] sk98lin: neuter and prepare for removal
Date: Tue, 18 Oct 2005 18:38:24 -0700
Message-ID: <4355A390.9090309@osdl.org>
References: <10182005213059.12304@bilbo.tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	jgarzik@pobox.com, mlindner@syskonnect.de, rroesler@syskonnect.de
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932460AbVJSBlQ@vger.kernel.org>
To: "John W. Linville" <linville@tuxdriver.com>
In-Reply-To: <10182005213059.12304@bilbo.tuxdriver.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

John W. Linville wrote:

>These patches take steps towards removing sk98lin from the upstream
>kernel.
>
>	-- Remove sk98lin's MODULE_DEVICE_TABLE to avoid
>	confusing userland tools about which driver to load;
>
>	-- Mark sk98lin as Obsolete in the MAINTAINERS file; and,
>
>	-- Add sk98lin to the feature-removal-schedule.txt file in the
>	Documentation directory.
>
>I accept the possibility that I may be jumping the gun on this.
>However, I think it is worth opening this discussion.
>
>Patches to follow...
>  
>
I applaud the initiative, but this it is too premature to obsolete the 
existing driver. There may be lots of chip versions and other variables 
that make
the existing driver a better choice.  Maybe eepro100 is a better target
for removal right now.
