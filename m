From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH RFC] wimax/i2400m: fixup completion handling for resetting
 a device
Date: Wed, 18 Mar 2015 15:29:21 +0300
Message-ID: <55096FA1.9030908@cogentembedded.com>
References: <1426585774-24204-1-git-send-email-hofrat@osadl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-wimax@intel.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Nicholas Mc Guire <hofrat@osadl.org>,
	Inaky Perez-Gonzalez <inaky.perez-gonzalez@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1426585774-24204-1-git-send-email-hofrat@osadl.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 3/17/2015 12:49 PM, Nicholas Mc Guire wrote:

> wait_for_completion_timeout return 0 (timeout) or >=1 (completion) so the check
> for > 0 in the else branch is always true and can be dropped. The comment seems
> misleading as it is always going to pass the result up.

> The sync of the completion access with __i2400m_dev_reset_handle (which checks
> for   if (i2400m->reset_ctx)   could race if i2400m_reset() returns negative so
> the resetting of i2400m->reset_ctx == NULL is moved to the out: path.

> As wait_for_completion_timeout returns unsigned long not int, an appropriately
> named variable of type unsigned long is added and assignments fixed up.

    Don't try to do several things in one patch.

> Signed-off-by: Nicholas Mc Guire <hofrat@osadl.org>

[...]

WBR, Sergei
