From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH] testptp: Silence compiler warnings on ppc64
Date: Tue, 29 Sep 2015 19:46:09 +0200
Message-ID: <20150929174609.GA7957@localhost.localdomain>
References: <1443541528-937-1-git-send-email-thuth@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, corbet@lwn.net, linux-doc@vger.kernel.org,
	trivial@kernel.org
To: Thomas Huth <thuth@redhat.com>
Return-path: <linux-doc-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1443541528-937-1-git-send-email-thuth@redhat.com>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Sep 29, 2015 at 05:45:28PM +0200, Thomas Huth wrote:
> This happens because __s64 is by default defined as "long" on ppc64,
> not as "long long". However, to fix these warnings, it's possible to
> define the __SANE_USERSPACE_TYPES__ so that __s64 gets defined to
> "long long" on ppc64, too.
> 
> Signed-off-by: Thomas Huth <thuth@redhat.com>

Acked-by: Richard Cochran <richardcochran@gmail.com>
