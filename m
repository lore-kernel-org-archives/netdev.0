From: Richard Cochran <richardcochran-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 1/2] posix clocks: introduce a syscall for clock tuning.
Date: Sat, 4 Sep 2010 16:06:39 +0200
Message-ID: <20100904140639.GA22074@riccoc20.at.omicron.at>
References: <cover.1283504065.git.richard.cochran@omicron.at>
 <7f4815cdfcf5bc49df4bdd09d59a4f56ca2598f5.1283504065.git.richard.cochran@omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <7f4815cdfcf5bc49df4bdd09d59a4f56ca2598f5.1283504065.git.richard.cochran-3mrvs1K0uXizZXS1Dc/lvw@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, Sep 03, 2010 at 11:29:05AM +0200, Richard Cochran wrote:
> A new syscall is introduced that allows tuning of a POSIX clock. The
> syscall is implemented for four architectures: arm, blackfin, powerpc,
> and x86.
> 
> The new syscall, clock_adjtime, takes two parameters, the clock ID,
> and a pointer to a struct timex. The semantics of the timex struct
> have been expanded by one additional mode flag, which allows an
> absolute offset correction. When specificied, the clock offset is
> immediately corrected by skipping to the new time value.

Sorry, last sentence should read, "corrected by adding the given time
value to the current time value."

Richard
