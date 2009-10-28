From: William Allen Simpson <william.allen.simpson@gmail.com>
Subject: Re: [PATCH 2/3] net: TCP thin linear timeouts
Date: Tue, 27 Oct 2009 23:20:39 -0400
Message-ID: <4AE7B887.6090806@gmail.com>
References: <4AE72079.4030504@simula.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	shemminger@vyatta.com, ilpo.jarvinen@helsinki.fi,
	davem@davemloft.net
To: Andreas Petlund <apetlund@simula.no>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932567AbZJ1DUj@vger.kernel.org>
In-Reply-To: <4AE72079.4030504@simula.no>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Sorry to be too picky about the naming, but "rm_expb" really doesn't
mean what is actually done.  Perhaps TCP_THIN_LINEAR_BACKOFF and
sysctl_tcp_thin_linear_backoff?

Also, as debated on some other recent patches, shouldn't the global
sysctl specify the default, and the per socket option specify the
forced override?
