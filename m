From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH 09/17] Tools: hv: Represent the ipv6 mask using CIDR
 notation
Date: Tue, 24 Jul 2012 19:08:32 +0200
Message-ID: <20120724170832.GB13749@x1.osrc.amd.com>
References: <1343145672-3641-1-git-send-email-kys@microsoft.com>
 <1343145701-3691-1-git-send-email-kys@microsoft.com>
 <1343145701-3691-9-git-send-email-kys@microsoft.com>
 <20120724160108.GA13749@x1.osrc.amd.com>
 <426367E2313C2449837CD2DE46E7EAF9236A7733@SN2PRD0310MB382.namprd03.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"devel@linuxdriverproject.org" <devel@linuxdriverproject.org>,
	"virtualization@lists.osdl.org" <virtualization@lists.osdl.org>,
	"olaf@aepfle.de" <olaf@aepfle.de>,
	"apw@canonical.com" <apw@canonical.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"ben@decadent.org.uk" <ben@decadent.org.uk>
To: KY Srinivasan <kys@microsoft.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <426367E2313C2449837CD2DE46E7EAF9236A7733@SN2PRD0310MB382.namprd03.prod.outlook.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jul 24, 2012 at 04:53:50PM +0000, KY Srinivasan wrote:
> This code is a user-level daemon that will be compiled outside of the
> kernel. I did not want to include Kernel header files for this one
> function and deal with all the dependencies that will have to be dealt
> with.

Ah, I missed the tools/ prefix in the patch, sorry.

Well, FWIW, we have hweight32 in <tools/perf/util/hweight.c> too and
there was a patchset preparing a generic kernel tools library where
tools can share functions but the author doesn't have time to dust the
patches off and get it upstream... :-).

I guess having a local function is the easiest for now.

Thanks.

-- 
Regards/Gruss,
Boris.
