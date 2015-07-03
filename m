From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH v2 0/1] Add PTP cross-timestamp to the PTP driver
 interface
Date: Fri, 3 Jul 2015 08:49:34 +0200
Message-ID: <20150703064934.GA1751@localhost.localdomain>
References: <1435886088-13890-1-git-send-email-christopher.s.hall@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	john.ronciak@intel.com, john.stultz@linaro.org, tglx@linutronix.de
To: Christopher Hall <christopher.s.hall@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1435886088-13890-1-git-send-email-christopher.s.hall@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jul 02, 2015 at 06:14:47PM -0700, Christopher Hall wrote:
> This patch adds an additional callback getsynctime64(). Which will be called 
> when the driver is able to perform a more accurate, implementation specific 
> cross-timestamping.  For example, future network devices that implement 
> PCIE PTM will be able to precisely correlate the device clock with the system 
> clock with virtually zero latency between captures.  This added callback can 
> be used by the driver to expose this functionality.

This discription is now much more clear to me, thanks.  Since there is
only one patch, please put this text into the commit message and drop
the cover letter.

Thanks,
Richard
