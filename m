From: Jean Delvare <khali@linux-fr.org>
Subject: Re: bonding sysfs output
Date: Wed, 5 Dec 2007 23:59:05 +0100
Message-ID: <20071205235905.7e8ac1b1@hyperion.delvare>
References: <87tznafjeu.fsf@szonett.ki.iif.hu>
	<20071125205150.4e49915f.akpm@linux-foundation.org>
	<87lk8lflzf.fsf@szonett.ki.iif.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Wagner Ferenc <wferi@niif.hu>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753390AbXLEW7V@vger.kernel.org>
In-Reply-To: <87lk8lflzf.fsf@szonett.ki.iif.hu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Wagner,

On Mon, 26 Nov 2007 09:29:40 +0100, Wagner Ferenc wrote:
> On the policy side: some files are not applicable to some types of
> bonds, and return a single linefeed in that case.  Except for one
> single case, which returns 'NA\n'.  The patch changes these cases into
> emtpy files.

IMHO a better approach would be to not create the files at all when
they make no sense for a given type of bond.

-- 
Jean Delvare
