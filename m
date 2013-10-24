From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: [PATCH NEXT 1/5] staging: r8188eu: Fix sparse warnings in
 ioctl_linux.c
Date: Thu, 24 Oct 2013 09:46:53 -0500
Message-ID: <526932DD.2080602@lwfinger.net>
References: <1382585497-6787-1-git-send-email-Larry.Finger@lwfinger.net>
 <1382585497-6787-2-git-send-email-Larry.Finger@lwfinger.net>
 <20131024101001.GD5871@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Cc: devel@driverdev.osuosl.org, gregkh@linuxfoundation.org,
 netdev@vger.kernel.org
To: Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <20131024101001.GD5871@mwanda>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: driverdev-devel-bounces@linuxdriverproject.org
List-Id: netdev.vger.kernel.org

On 10/24/2013 05:10 AM, Dan Carpenter wrote:
> I have looked at how this is called from ioctl_private_call() and it
> seems like these are actual user pointers and the code is buggy.  The
> patch silences the warnings instead of fixing the bugs.

Thanks for the review.

Greg - please drop this one and take only 2-5. Do you want a resubmission?

Larry
